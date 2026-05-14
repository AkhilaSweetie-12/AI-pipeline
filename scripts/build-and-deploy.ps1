# AI Platform Build and Deploy Script (PowerShell)
$ErrorActionPreference = "Stop"

$PROJECT_ID = "akhila-gcp-123-493309"
$REGION = "asia-south1"
$REGISTRY = "asia-south1-docker.pkg.dev"
$BACKEND_IMAGE = "$REGISTRY/$PROJECT_ID/ai-platform/ai-platform-backend:latest"
$FRONTEND_IMAGE = "$REGISTRY/$PROJECT_ID/ai-platform/ai-platform-frontend:latest"

Write-Host "Building and deploying AI Platform..." -ForegroundColor Green

# Step 1: Build Backend
Write-Host "Building backend..." -ForegroundColor Blue
Set-Location "backend"
docker build -t ai-platform-backend:latest .
docker tag ai-platform-backend:latest $BACKEND_IMAGE

# Step 2: Build Frontend
Write-Host "Building frontend..." -ForegroundColor Blue
Set-Location "../frontend"
docker build -t ai-platform-frontend:latest .
docker tag ai-platform-frontend:latest $FRONTEND_IMAGE

# Step 3: Authenticate to Artifact Registry
Write-Host "Authenticating to Artifact Registry..." -ForegroundColor Blue
gcloud auth configure-docker $REGISTRY

# Step 4: Push Images
Write-Host "Pushing backend image..." -ForegroundColor Blue
docker push $BACKEND_IMAGE

Write-Host "Pushing frontend image..." -ForegroundColor Blue
docker push $FRONTEND_IMAGE

# Step 5: Deploy to Kubernetes
Write-Host "Deploying to Kubernetes..." -ForegroundColor Blue
Set-Location "../kubernetes/manifests"
kubectl apply -f redis.yaml
kubectl apply -f configmap.yaml
kubectl apply -f backend-deployment.yaml
kubectl apply -f frontend-deployment.yaml
kubectl apply -f services.yaml
kubectl apply -f ingress.yaml

# Step 6: Wait for deployments
Write-Host "Waiting for deployments to be ready..." -ForegroundColor Blue
kubectl wait --for=condition=available --timeout=300s deployment/ai-platform-backend
kubectl wait --for=condition=available --timeout=300s deployment/ai-platform-frontend
kubectl wait --for=condition=available --timeout=300s deployment/redis

# Step 7: Show status
Write-Host "Deployment status:" -ForegroundColor Cyan
kubectl get pods
kubectl get services
kubectl get ingress

Write-Host "Deployment completed successfully!" -ForegroundColor Green
Write-Host "Frontend URL: https://aiplatform.example.com" -ForegroundColor Cyan
Write-Host "Backend API: https://aiplatform.example.com/api" -ForegroundColor Cyan
