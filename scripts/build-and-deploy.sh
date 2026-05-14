#!/bin/bash

# AI Platform Build and Deploy Script
set -e

PROJECT_ID="akhila-gcp-123-493309"
REGION="asia-south1"
REGISTRY="asia-south1-docker.pkg.dev"
BACKEND_IMAGE="$REGISTRY/$PROJECT_ID/ai-platform/ai-platform-backend:latest"
FRONTEND_IMAGE="$REGISTRY/$PROJECT_ID/ai-platform/ai-platform-frontend:latest"

echo "Building and deploying AI Platform..."

# Step 1: Build Backend
echo "Building backend..."
cd backend
docker build -t ai-platform-backend:latest .
docker tag ai-platform-backend:latest $BACKEND_IMAGE

# Step 2: Build Frontend
echo "Building frontend..."
cd ../frontend
docker build -t ai-platform-frontend:latest .
docker tag ai-platform-frontend:latest $FRONTEND_IMAGE

# Step 3: Authenticate to Artifact Registry
echo "Authenticating to Artifact Registry..."
gcloud auth configure-docker $REGISTRY

# Step 4: Push Images
echo "Pushing backend image..."
docker push $BACKEND_IMAGE

echo "Pushing frontend image..."
docker push $FRONTEND_IMAGE

# Step 5: Deploy to Kubernetes
echo "Deploying to Kubernetes..."
cd ../kubernetes/manifests
kubectl apply -f redis.yaml
kubectl apply -f configmap.yaml
kubectl apply -f backend-deployment.yaml
kubectl apply -f frontend-deployment.yaml
kubectl apply -f services.yaml
kubectl apply -f ingress.yaml

# Step 6: Wait for deployments
echo "Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/ai-platform-backend
kubectl wait --for=condition=available --timeout=300s deployment/ai-platform-frontend
kubectl wait --for=condition=available --timeout=300s deployment/redis

# Step 7: Show status
echo "Deployment status:"
kubectl get pods
kubectl get services
kubectl get ingress

echo "Deployment completed successfully!"
echo "Frontend URL: https://aiplatform.example.com"
echo "Backend API: https://aiplatform.example.com/api"
