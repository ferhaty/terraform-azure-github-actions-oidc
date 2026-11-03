# Terraform on Azure with GitHub Actions and OIDC

Companion examples for **Deploying Terraform to Azure with GitHub Actions and OIDC** by Turing Technology Services. Visit the [Turing Technology Services blog](https://blog.turingts.com/).

## Safe example layout

All runnable source is under [`store-infra/`](store-infra/). In particular, workflow examples live at `store-infra/.github/workflows/`, **not** at the repository root. GitHub Actions does not run these nested example files. Cloning or pushing to this public example repository does not start an Azure deployment.

```text
store-infra/
  bootstrap/             # Administrator-owned identity, federation and Blob state
  terraform/             # Service Bus namespace and order-events queue
    vars/                 # Dev, Stage and Production inputs and backend examples
    tests/                # Mock-provider tests
  .github/workflows/     # Inert PR, deployment and reusable-workflow examples
```

Terraform configuration, tests, action pins and provider locks are included. Providers, state, plans, credentials and article artwork are not.

## Get the examples

```bash
git clone https://github.com/ferhaty/terraform-azure-github-actions-oidc.git
cd terraform-azure-github-actions-oidc/store-infra
```

Run sample-relative commands from this `store-infra` directory. See the [sample README](store-infra/README.md) for prerequisites and local checks. Terraform is pinned to 1.17.1 and AzureRM to 5.12.0. Lockfiles include Linux amd64 and macOS arm64 checksums; local execution was checked on Linux, not on macOS.

## Local validation, without Azure deployment

Use a clean shell with no Azure, managed-identity or GitHub OIDC credentials and no active Azure CLI login. Set the following only in that clean validation shell:

```bash
export ARM_USE_CLI=false ARM_USE_MSI=false ARM_USE_OIDC=false TF_INPUT=false
terraform fmt -check -recursive
terraform -chdir=bootstrap init -input=false -lockfile=readonly
terraform -chdir=bootstrap validate
terraform -chdir=bootstrap test
terraform -chdir=terraform init -backend=false -input=false -lockfile=readonly
terraform -chdir=terraform validate
terraform -chdir=terraform test
```

Every Terraform test uses `mock_provider "azurerm"`. Its `command = apply` is a mocked operation, not an Azure deployment. Initialization downloads the pinned provider; it does not create cloud resources. These local checks do not establish live Azure permissions, OIDC exchanges, GitHub approval behaviour or deployment success. No live cloud deployment was performed for this repository.

## Adapting the sample for your own private repository

Do not activate the workflows in this public example repository. If you choose to implement the deployment path, copy the **contents** of `store-infra/`, including its hidden `.github` and `.gitignore`, into your own separately configured **private** repository. Configure the following before enabling workflows or pushing their first active commit:

- Use three existing Azure subscriptions: Dev, Stage and Production. A common existing Entra tenant and Azure public cloud/West Europe are the example's proposed defaults, not discovered account settings.
- An administrator creates each subscription's foundation separately, using a secured local working directory and independent state. The foundation contains one user-assigned managed identity, its exact GitHub environment federation, private Blob state and the dedicated workload resource group. Never switch subscriptions over existing bootstrap state.
- Preregister `Microsoft.Storage`, `Microsoft.ManagedIdentity` and `Microsoft.ServiceBus` as an administrator. Replace every example storage account, namespace, subscription/tenant value and immutable GitHub repository subject with your own intended values. UUIDs in tests and `example-org@123/store-infra@456` are synthetic fixtures, not deployment identities.
- Pre-create `dev`, `stage` and `production` GitHub environments. Set `AZURE_CLIENT_ID`, `AZURE_TENANT_ID` and `AZURE_SUBSCRIPTION_ID` as environment variables from each foundation's outputs. Dev permits main and trusted same-repository PR merge refs without reviewers. Stage and Production permit main only and require reviewer approval before **both** plan and apply. Required reviewers in private repositories require an eligible GitHub plan. Referencing an environment in YAML does not configure its protection rules.
- Plan and apply use the same deployment-capable identity. Contributor is scoped to the dedicated workload resource group, and Storage Blob Data Contributor separately to the state container. These are not read-only planning credentials. Do not run untrusted or fork PR code with them.

Once deliberately activated in that private repository, `pr.yml` checks and plans trusted PRs against Dev. A merge to main starts `deploy.yml`: automatic Dev, then approved Stage plan/apply, then approved Production plan/apply. The reusable workflow checks out the same revision, prints the plan in the job log and transfers only the saved binary plan by its artifact ID. Approval gaps do not reserve Terraform state; regenerate stale plans rather than applying them.

No Azure login, deployment, workflow dispatch, repository environment or cloud credential is configured by publishing these examples.

## Dependencies and attribution

The examples reference HashiCorp Terraform/AzureRM and the GitHub Actions listed at their pinned commits in the YAML files. Those projects retain their own upstream licences and attribution. No third-party provider or action source is vendored here. This repository does not grant a blanket licence to the associated article, images or other works.
