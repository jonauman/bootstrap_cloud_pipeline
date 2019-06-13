## Prerequisites
* working Docker installation
* [AWS access key](https://aws.amazon.com/premiumsupport/knowledge-center/create-access-key/)

## Setup Terraform
* Build Dockerfile to run terraform within a container

  `docker build -t [your_docker_repo]:terraform-deployer`
  
* While we are still in a bit of a trial and error stage, it's easiest to run the commands from within the terraform-deployer container.

  ```
  docker run -itd [your_docker_repo]:terraform-deployer
  docker exec -it [container_id] bash
  ```
  
* setup remote terraform state file with locking. More info [here](https://medium.com/@jessgreb01/how-to-terraform-locking-state-in-s3-2dc9a5665cb6). From within the container:
  ```
  cd bootstrap_cloud_pipeline/aws/components/terraform_locking/
  export AWS_DEFAULT_REGION=eu-west-2
  export AWS_ACCESS_KEY_ID=[your access key]
  export AWS_SECRET_ACCESS_KEY=[your secret key]
  terraform init
  terraform plan
  terraform apply
  ```
  
* This will setup an S3 bucket and Dynamodb table for storing state files for each our our components. We are going to start off with a `pipeline` component but will add more later, such as VPC, Elastic Beanstalk, etc.

* Next we need to uncomment backend.tf and replace the `bucket` and `dynamodb` values as at least the bucket name will be different in your case. We append a md5 hash of your AWS account id to the bucket name because S3 bucket names need to be unique globally for all AWS customers and this is a handy trick to generate a predicatable GUID.

* Run `terraform init` again and it will upload your local terraform state file to S3 and create a version entry in dynamodb.

## Setup pipeline

* Now to setup the pipeline
  ```
  cd ../pipeline/
  terraform init
  terraform plan
  terraform apply
  ```
 
* The apply command should have output both an https and a ssh git url of your CodeCommit repo. If you are not an AWS admin in your account or do not have permission to all CodeCommit commands, you will need to add a policy to allow your AWS principle access to the repo. More info [here.](https://docs.aws.amazon.com/codecommit/latest/userguide/auth-and-access-control.html)

* I found it easiest to use the ssh url, and instructions [here.](https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-ssh-unixes.html). There are also links on that page for Windows setup.

* Create a `hello-world` dockerfile and push to this repo. You can copy a sample [here.](https://github.com/jonauman/hello-world-docker) If you are beyond proof of concept stage, you should upload the app you want to publish here instead.

* Now you can find the CodeBuild job in the AWS console and run it. This will build the hello-world app and store in ECR, Amazon's docker registry.

## To do
* create CodePipeline in terraform. This will consist of mulitple stages
  * build stage, this runs the CodeBuild that we ran manually in the stage above
  * deploy to dev stage. This will deploy the image stored in ECR as a docker container in the dev elastic beanstalk.
  * test dev stage will run some automated tests, such as functional tests
  * deploy to QA stage. will deploy the image stored in ECR as a docker container in the QA elastic beanstalk.
  *test QA stage. This might run some integration tests with other apps and external services, for example.
  * And so on through the ennvironments until you get to Prod.

## More to do
* probably we will need to setup a VPC, subnets, and security groups to work with Elastic Beanstalk
* We will also need to configure elastic beanstalk outside of CodePipeline, if memory serves me. CodePipeline will not create the elastic beanstalk config for us.
* Setup cross-account deployments. In the real world, we will most likely be deploying to multiple AWS accounts.

