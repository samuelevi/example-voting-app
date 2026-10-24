param(
  [string]$Region = "eu-west-1",
  [string]$Cluster = "voting-app"
)

aws eks update-kubeconfig --region $Region --name $Cluster
kubectl create namespace voting --dry-run=client -o yaml | kubectl apply -f -

kubectl -n voting get secret db-credentials 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
  $bytes = New-Object byte[] 24
  [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
  $pw = [Convert]::ToBase64String($bytes) -replace '[+/=]',''
  kubectl -n voting create secret generic db-credentials `
    --from-literal=POSTGRES_USER=postgres `
    --from-literal=POSTGRES_PASSWORD=$pw
  Write-Host "Created db-credentials with a generated password."
} else {
  Write-Host "db-credentials already exists; leaving it alone."
}