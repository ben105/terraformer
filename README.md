# terraformer
Terraforms new applications.

*I need to make the distinction between the root terraformer and root infrastructure, and the infrastructure that needs to be spun up.*

*I need to differentiate between the initial root terraformer and root infrastructure install steps, which should only happen once, and the steps to initialize a new project, which will happen N times.*

## Prepare the Infrastructure

### Set up your GCP configuration to use the project that you will be working with:
```bash
gcloud config set project $PROJECT_ID
```

### The next step is to set your own user credentials for Terraform in order to access the APIs:
```bash
gcloud auth application-default login
```

### Create a service account for your project.
   
Tip: The short name can be something related to the project name you are using.

Example:
```bash
gcloud iam service-accounts create terraformer-{short_project_name} \
  –description=”Terraform Service account Dev Environment” \
  –display-name=”Terraform Service Account”
```

### Provide your freshly created service account with the necessary roles and permissions:
```bash
gcloud projects add-iam-policy-binding $PROJECT_ID \
  –member=”serviceAccount:${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com” \
  –role=”roles/editor”
```

### We will be impersonating this service account to make all our changes. In order to do this, we need to grant ourselves the necessary permissions. You can do it like this:

First get the policies for the service account and save it in policy.json:
```bash
gcloud iam service-accounts get-iam-policy ${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com \
  –format=json > policy.json
```
Modify the policy.json to add yourself as member to the role (roles/iam.serviceAccountTokenCreator). Remember to append the rest of policies that already exist:
```json
{
  "bindings": [
    {
      "members": [
        "user:user_name@domain.com"
      ],
      "role": "roles/iam.serviceAccountTokenCreator"
    }
  ],
  ... rest of policies
}
```
Update the policies with the policy.json file:
```bash
gcloud iam service-accounts set-iam-policy ${SERVICE_ACCOUNT}@${PROJECT_ID}.gserviceaccount.com \
  policy.json
```

### Create a bucket that will hold your Terraform State

Now choose the name of the bucket. You can use this naming convention: {short_project_name}-{Environment}-tf-state.

```bash
gsutil mb -l gs://testapp-dev-tf-state
gsutil versioning set on gs://testapp-dev-tf-state
```

## Terraform Setup

```
tf-code
│ main.tf
│ testapp-dev.tfvars
│ testapp-dev.backend
│ variables.tf
│ version.tf
│
└───module1
│ │ main.tf
│ │ outputs.tf
│ │ varialbes.tf
│
└───module2
│ │ main.tf
│ │ outputs.tf
│ │ varialbes.tf
│
…
```

### main.tf
```tf
provider "google" {
  project = var.project_id
  region = var.region
  zone = var.zone
  impersonate_service_account = var.tf_service_account
}
```

### testapp-dev.tfvars
```
project_id = "demo-sbx-tf-state"
region = "us-west1"
zone = "us-west1-a"
tf_service_account = "SERVICE_ACCOUNT@PROJECT_ID.iam.gserviceaccount.com"
```

### testapp-dev.backend
```
bucket = "testapp-dev-tf-state"
prefix = "static.tfstate.d"
impersonate_service_account = "SERVICE_ACCOUNT@PROJECT_ID.iam.gserviceaccount.com"
```

### version.tf

This will enable you to keep track of exactly which version of Terraform you are using and each provider that is required.
```tf
terraform {
   required_version = ">= 1.3.0"
   backend "gcs" {}
   required_providers {
      google = {
         source  = "hashicorp/google"
         version = ">= 5.10.0"
      }
      google-beta = {
         source  = "hashicorp/google-beta"
         version = ">= 5.10.0"
      }
   }
}

data "google_project" "project" {
  project_id = var.project
}

data "google_app_engine_default_service_account" "appengine-default" {
  project = var.project
}

resource "google_compute_network" "vpc_network" {
  name = "vpc-network"
}
```

### Initialise the Terraform code
```bash
terraform init -backend-config=testapp-dev.backend
```

### Create a workspace
```bash
terraform workspace new testapp-dev
```

### Plan and apply

*This is for the testapp, but I also want to seperate out how to plan/apply the root infrastructure and terraformer.*

```bash
terraform plan –out tf.plan –var-file=testapp-dev.tfvars
```
