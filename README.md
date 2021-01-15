# DevOps Engineer - Technical Test	
We think infrastructure is best represented as code, and provisioning of resources should be automated as much as possible.	

 Your task is to create a CI build pipeline that deploys this web application to a load-balanced	
environment. You are free to complete the test in a local environment (using tools like Vagrant and	
Docker) or use any CI service, provisioning tool and cloud environment you feel comfortable with (we	
recommend creating a free tier account so you don't incur any costs).	

 * Your CI job should:	
  * Run when a feature branch is pushed to Github (you should fork this repository to your Github account). If you are working locally feel free to use some other method for triggering your build.	
  * Deploy to a target environment when the job is successful.	
* The target environment should consist of:	
  * A load-balancer accessible via HTTP on port 80.	
  * Two application servers (this repository) accessible via HTTP on port 3000.	
* The load-balancer should use a round-robin strategy.	
* The application server should return the response "Hi there! I'm being served from {hostname}!".	

 ## Context	
We are testing your ability to implement modern automated infrastructure, as well as general knowledge of system administration. In your solution you should emphasize readability, maintainability and DevOps methodologies.	

 ## Submit your solution	
Create a public Github repository and push your solution in it. Commit often - we would rather see a history of trial and error than a single monolithic push. When you're finished, send us the URL to the repository.	

 ## Running this web application	
 This is a NodeJS application:	This is a NodeJS application:

- `npm test` runs the application tests	- `npm test` runs the application tests
- `npm start` starts the http server

# Solution
The solution I came up was to have my CI/CD pipeline provisioned in Github Actions (as it's managed) and built all the required Infra using Terraform hosted in AWS.

* My Github Actions CI/CD Pipeline:  https://github.com/umair-io/devops-test/actions
* Hosted Website: [wipro-devops.umair.uk](http://wipro-devops.umair.uk/) (*Will be live until 31/01/2021*).

## Solution Design 
![Solution Diagram](images/builtit-exercise-diagram.PNG?raw=true "Solution Diagram")

The solution diagram above shows the Infrastructure to built and how Application is deployed from code in GitHub to being hosted in AWS on multiple servers behind an Application Load Balancer. The resilliance in the solution is provided by it being hosted via an AWS Autoscaling group across two AZs. The solution also ensures zero downtime during a deployment (given an AWS AZ does not become unavailable).

## Pipeline Design
* Pipeline is split in to 2 parts:
  * CI
  * CD
* Pipeline is run every time a push is made to any branch. However, the CD part of the pipeline only runs when a commit (or a merge request) is made against the master branch. 
* The CD part of the pipeline also requires that the version of the application has been updated in the `package.json` file (else it will fail).
* After code is tested, pipeline uploads the latest version/tag of the code to the s3 bucket (using aws cli) and also uploads the same code to replace the existing cide in "latest" dir which ec2 instances in the ASG group will pick up from.
* Finally, the pipeline uses aws cli's autoscaling instance-refresh command to trigger ASG (AutoScalingGroup) to rebuild the instances at which point, they take the latest code from the s3 bucket during the initialising phase. The update is done in a rolling manner to avoid any downtime.


## Running the Solution
### Pre Reqs
* Terraform installed on the local system.
* This repo forked.
* Generated 'Access Key ID' and 'Secret Access Key' and then stored them in the forked Github repo Secrets (Settings->Secrets->New repository secret) e.g.
  * AWS_KEY = [YOUR ACCESS KEY ID]
  * AWS_SECRET = [YOUR AWS SECRET ACCESS KEY]
* Also secrets set for AWS Bucket and AWS Region (matching ones set in infra/variables.tf) e.g.
  * AWS_BUCKET = 'wipro-release-uk'
  * AWS_REGION = 'us-east-1'

### Setting Local Computer
* Clone forked git repo:
```
$ git clone git@github.com:[YOUR_FORKED_REPO].git
```
* Set aws credentials and region (same as the one set in gitlab secrets) on your computer:
```
$ aws configure
AWS Access Key ID : [YOUR ACCESS KEY ID]
AWS Secret Access Key : [YOUR AWS SECRET ACCESS KEY]
Default region name : [YOUR CHOSEN REGION]
Default output format: [EMPTY]
```

### Building Infra (using Terraform)
* Run terraform apply to build all the required Infra:
```
cd devops-test/infra
terraform init
terraform apply --auto-approve
```

Output should look something like below (which means your Infra is ready for your pipeline!):
```
Apply complete! Resources: 21 added, 0 changed, 0 destroyed.

Outputs:

lb-address = "wipro-alb-745115038.us-west-2.elb.amazonaws.com"
```
Make note of the loadbalancer dns address. We will use it later to test the website.

### Running the Pipeline
To run the pipeline and deploy to AWS, update/increment application version in package.json `(else the deployment won't be successful)`, commit and push the change to the master branch.

* Go to the repo dir.
```
cd devops-test
```
* Update the version in `package.json`
* Commit and push
```
git commit -am "Updating the app version
```
This trigger the pipeline which can viewed under `Actions` section on repo's Github page. 

* After about 5 minutes (takes time as it's rolling update to avoid downtime) visit (or curl) the LoadBalancer's DNS address which was printed in the terraform output:
```
curl wipro-alb-XXXXX.XXXXX.elb.amazonaws.com
```