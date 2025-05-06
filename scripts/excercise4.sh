
# step1: try re-create AD app - we will get credentials from excercise2 
# and assign RBAC role
applicationRegistrationDetails=$(az ad app create --display-name 'toy-website-workflow')
applicationRegistrationObjectId=$(echo $applicationRegistrationDetails | jq -r '.id')
applicationRegistrationAppId=$(echo $applicationRegistrationDetails | jq -r '.appId')

resourceGroupResourceId=$(az group create --name ToyWebsite --location eastus --query id --output tsv)

az role assignment create \
   --assignee $applicationRegistrationAppId \
   --role Contributor \
   --scope $resourceGroupResourceId


githubUser='pawelsiwek'
githubRepo='global-azure-2025-gdn'
federatedCredentialPolicy='{
  "name": "MyFederatedCredential3",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:'$githubUser'/'$githubRepo':environment:Website",
  "audiences": [
    "api://AzureADTokenExchange"
  ]
}'

az ad app federated-credential create \
  --id $applicationRegistrationObjectId \
  --parameters "$federatedCredentialPolicy"


#step6: cleanup
az group delete --resource-group ToyWebsite --yes --no-wait
