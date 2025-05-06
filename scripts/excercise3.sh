# 1) Create entra application
applicationRegistrationName="kapitan-bomba"
applicationRegistrationDetails=$(az ad app create --display-name $applicationRegistrationName)

#) 1 Create Resource Group
resourceGroupId=$(az group create --name ToyWebsite --location eastus --query id --output tsv)

# 2) define federatedCredentialPolicy
githubUser="pawelsiwek"
githubRepo="global-azure-2025-gdn"

federatedCredentialPolicy='{
  "name": "MyFederatedCredential",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:'$githubUser'/'$githubRepo':ref:refs/heads/main",
  "audiences": [
    "api://AzureADTokenExchange"
  ]
}'

applicationRegistrationObjectId=$(echo $applicationRegistrationDetails | jq -r '.id')
applicationRegistrationAppId=$(echo $applicationRegistrationDetails | jq -r '.appId')

az ad app federated-credential create \
  --id $applicationRegistrationObjectId \
  --parameters "$federatedCredentialPolicy"

# 2) Grant RBAC Contributor role
az ad sp create --id $applicationRegistrationObjectId

az role assignment create \
   --assignee $applicationRegistrationAppId \
   --role Contributor \
   --scope $resourceGroupId \
   --description "The deployment workflow for the company's website needs to be able to create resources within the resource group."



#step6: cleanup
az group delete --resource-group ToyWebsite --yes --no-wait