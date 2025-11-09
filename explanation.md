# Week 5 Kubernetes Project - Implementation Explanation

This document explains the design choices and implementation details for deploying the YOLO e-commerce application on AWS Elastic Kubernetes Service (EKS).

---

## 1. Choice of Kubernetes Objects Used for Deployment

### MongoDB - StatefulSet ✅

**Decision:** Used a **StatefulSet** instead of a regular Deployment for MongoDB.

**Reasoning:**
- **Stable Network Identity**: StatefulSets provide stable, predictable pod names (e.g., `mongodb-0`) which persist across rescheduling. This is crucial for database workloads where stable hostnames are required for connection strings.
- **Ordered Deployment & Scaling**: Pods are created, updated, and deleted in a predictable order (0, 1, 2...), ensuring data consistency during rolling updates.
- **Persistent Storage Integration**: StatefulSets work seamlessly with `volumeClaimTemplates`, automatically creating a unique PersistentVolumeClaim (PVC) for each replica. This ensures each database instance maintains its own persistent storage.
- **Stateful Data**: Unlike stateless applications, databases require data persistence and stable identifiers across restarts, making StatefulSets the appropriate choice.

**Implementation Details:**
- Configured with `volumeClaimTemplates` to automatically provision 5Gi EBS volumes
- Used a headless service (`clusterIP: None`) to allow direct pod-to-pod communication using DNS names like `mongodb-0.mongodb-service`
- Set resource limits (256Mi memory, 250m CPU requests) to prevent resource exhaustion
- Used MongoDB 5.0 image for stability and compatibility

### Backend API - Deployment

**Decision:** Used a **Deployment** for the Node.js backend API.

**Reasoning:**
- **Stateless Nature**: The backend is a stateless service that doesn't store data locally
- **Rolling Updates**: Deployments support rolling updates with zero downtime
- **Scalability**: Easy horizontal scaling by adjusting replica count
- **Self-Healing**: Automatic pod replacement if failures occur

**Implementation Details:**
- Configured 2 replicas for high availability
- Added liveness and readiness probes to ensure traffic is only routed to healthy pods
- Set resource requests (128Mi memory, 100m CPU) and limits for optimal scheduling
- Exposed via ClusterIP service (internal only) since it's only accessed by the frontend

### Frontend - Deployment

**Decision:** Used a **Deployment** for the React frontend application.

**Reasoning:**
- **Stateless Application**: Frontend serves static assets and doesn't maintain session state
- **Load Balancing**: Multiple replicas distribute traffic evenly
- **Easy Updates**: Rolling updates allow seamless deployment of new versions
- **Horizontal Scaling**: Can scale based on user demand

**Implementation Details:**
- Configured 1 replica (increased from 2 to reduce resource usage on small cluster)
- Added stdin/tty flags to support React dev server in container environment
- Set appropriate resource constraints (128Mi memory, 100m CPU)

---

## 2. Method Used to Expose Pods to Internet Traffic

### Approach: LoadBalancer Service Type

**Frontend Exposure:**
- **Service Type**: LoadBalancer
- **Purpose**: Exposes the frontend application to external internet traffic
- **How it Works**: 
  - On AWS EKS, a LoadBalancer service automatically provisions an AWS Elastic Load Balancer (ELB)
  - The load balancer receives an external hostname accessible from the internet
  - Traffic is distributed across all healthy frontend pods
  - Port 3000 is exposed for HTTP access

**Backend Exposure:**
- **Service Type**: ClusterIP (internal only)
- **Purpose**: Backend is NOT exposed to the internet directly
- **Security**: Backend is only accessible within the cluster by the frontend pods
- **Communication**: Frontend communicates with backend using the internal service DNS name `backend-service:5000`

**MongoDB Exposure:**
- **Service Type**: Headless Service (ClusterIP: None)
- **Purpose**: Provides stable network identity for StatefulSet pods
- **Security**: Database is completely isolated from external traffic
- **Access Pattern**: Only accessible by backend pods using DNS `mongodb-0.mongodb-service:27017`

**External URL Format:**
```
http://a263a87fb0806478fb57ecdd53f82e49-973885211.us-east-1.elb.amazonaws.com:3000
```

**Alternative Approaches Considered:**
1. **NodePort**: Would expose services on each node's IP at a static port (30000-32767). Not ideal for production as it requires managing node IPs and doesn't provide load balancing.
2. **Ingress**: Could be used for more sophisticated routing, SSL termination, and path-based routing. Would be beneficial for multiple services on the same domain. Not implemented due to added complexity for single-service deployment.

---

## 3. Use of Persistent Storage

### Implementation: StatefulSet with VolumeClaimTemplates ✅

**Storage Strategy:**
- **PersistentVolumeClaim (PVC)**: Each MongoDB pod gets its own PVC automatically created by the StatefulSet's `volumeClaimTemplates`
- **PersistentVolume (PV)**: AWS EKS automatically provisions PVs backed by Amazon EBS (Elastic Block Store)
- **Storage Class**: Used `gp2` (AWS General Purpose SSD) which provides ReadWriteOnce access mode
- **Storage Size**: Allocated 5Gi per database instance

**AWS-Specific Implementation:**
- Installed AWS EBS CSI (Container Storage Interface) driver as an EKS addon
- EBS CSI driver enables dynamic provisioning of EBS volumes
- Storage class changed from `standard-rwo` (GCP default) to `gp2` (AWS default)

**Benefits:**
1. **Data Persistence**: Database data survives pod restarts, rescheduling, and node failures
2. **Automatic Provisioning**: No need to manually create PVs; AWS handles this dynamically
3. **Pod-to-Volume Binding**: Each StatefulSet pod maintains its association with its specific PVC even after rescheduling
4. **Data Isolation**: Each replica (if scaled) gets its own isolated storage

**Storage Lifecycle:**
- When StatefulSet is created → PVC is automatically created for each replica
- EKS provisions an EBS volume and binds it to the PVC
- MongoDB pod mounts the volume at `/data/db`
- Data persists even if pods are deleted (PVC remains)
- PVC must be manually deleted if permanent data removal is desired

**Why Not Used for Frontend/Backend:**
- Frontend and backend are stateless applications
- They don't store data locally; all persistent data goes to MongoDB
- Using ephemeral storage reduces complexity and cost
- Stateless pods can be easily replaced without data loss concerns

---

## 4. Git Workflow Used to Achieve the Task

### Branching Strategy
- **Main Branch**: Production-ready code with all working Kubernetes manifests
- **Development Approach**: Direct commits to main branch for this assignment (single developer)

### Development Workflow
1. **Initial Setup**: Created "Week 5 Kubernetes" directory in existing repository
2. **Iterative Development**:
   - Created each Kubernetes manifest file
   - Tested manifests locally using `kubectl apply --dry-run=client`
   - Committed changes with descriptive messages
3. **Commit Convention**: Used conventional commit format:
   - `feat: add MongoDB StatefulSet with persistent storage`
   - `feat: create backend Deployment with ClusterIP service`
   - `feat: implement frontend with LoadBalancer service`
   - `docs: add comprehensive explanation.md`
   - `fix: resolve frontend CrashLoopBackOff with stdin/tty`

### Commit History Example:
```
fc805ea - Merge branch 'main' of https://github.com/opiyo-cyber/Okoth
9548b68 - feat: add Week 5 Kubernetes deployment with StatefulSet
```

### Best Practices Followed
- **Atomic Commits**: Each commit represents a single logical change
- **Descriptive Messages**: Clear commit messages explaining what and why
- **.gitignore**: Excluded sensitive files, temporary files, and IDE configurations
- **Documentation**: Maintained comprehensive README and explanation files
- **Version Control**: All Kubernetes manifests tracked in Git

---

## 5. Successful Running of Applications & Debugging Measures

### Deployment Process

**Platform:** AWS EKS (Elastic Kubernetes Service)  
**Reason for AWS:** GCP access issues prevented GKE deployment

**Cluster Creation:**
```bash
eksctl create cluster \
  --name yolo \
  --region us-east-1 \
  --node-type t3.small \
  --nodes 1 \
  --managed
```

**Deployment Steps:**
1. Updated storage class from `standard-rwo` to `gp2` for AWS compatibility
2. Deployed MongoDB StatefulSet
3. Deployed Backend Deployment
4. Deployed Frontend Deployment
5. Retrieved LoadBalancer external hostname

### Expected Output
- **MongoDB StatefulSet**: 1/1 replica running with PVC bound
- **Backend Deployment**: 2/2 replicas running and healthy
- **Frontend Deployment**: 1/1 replica running and healthy
- **Frontend Service**: External LoadBalancer hostname assigned
- **Application URL**: http://a263a87fb0806478fb57ecdd53f82e49-973885211.us-east-1.elb.amazonaws.com:3000

### Debugging Measures Applied

#### Issue 1: PVC Stuck in Pending State
**Problem:** MongoDB PVC remained in Pending state for extended period

**Diagnosis:**
```bash
kubectl describe pvc mongodb-persistent-storage-mongodb-0
kubectl get events --sort-by='.lastTimestamp'
```

**Root Cause:** EBS CSI driver not installed on EKS cluster

**Solution:**
```bash
# Enable OIDC provider
eksctl utils associate-iam-oidc-provider --cluster=yolo --region=us-east-1 --approve

# Install EBS CSI driver addon
eksctl create addon --cluster=yolo --region=us-east-1 --name=aws-ebs-csi-driver --force
```

**Outcome:** PVC successfully bound to EBS volume after CSI driver installation

#### Issue 2: Backend and Frontend Pods in Pending State
**Problem:** Backend and frontend pods stuck in Pending after MongoDB started

**Diagnosis:**
```bash
kubectl get pods
kubectl describe pod <pod-name>
```

**Root Cause:** Insufficient resources on single t3.small node

**Solution:**
```bash
# Scale nodegroup from 1 to 2 nodes
eksctl scale nodegroup --cluster=yolo --nodes=2 --nodes-max=3 --name=nodes --region=us-east-1
```

**Outcome:** Pods scheduled successfully on new node

#### Issue 3: Frontend CrashLoopBackOff
**Problem:** Frontend pod repeatedly crashed with exit code 0

**Diagnosis:**
```bash
kubectl logs deployment/yolo-frontend --tail=50
kubectl describe pod <frontend-pod>
```

**Root Cause:** React dev server requires stdin/tty to run properly in container

**Solution:** Added to frontend deployment:
```yaml
containers:
- name: frontend
  stdin: true
  tty: true
```

**Outcome:** Frontend pod ran successfully

#### Issue 4: "Invalid Host Header" Error
**Problem:** Browser showed "Invalid Host Header" when accessing LoadBalancer URL

**Diagnosis:** React dev server security check rejects requests from unknown hostnames

**Root Cause:** React dev server (webpack-dev-server) validates hostname for security

**Solution:** Added environment variable to disable host check:
```yaml
env:
- name: DANGEROUSLY_DISABLE_HOST_CHECK
  value: "true"
```

**Outcome:** Application accessible via LoadBalancer hostname

### Monitoring Commands Used
```bash
# Check pod status
kubectl get pods -o wide

# View pod logs
kubectl logs -f deployment/yolo-backend

# Check service endpoints
kubectl get endpoints

# Describe resources for detailed info
kubectl describe statefulset mongodb

# Check persistent volumes
kubectl get pv,pvc

# View cluster events
kubectl get events --sort-by='.lastTimestamp'
```

---

## 6. Good Practices: Docker Image Tag Naming Standards

### Docker Hub Image Standards

**Naming Convention Used:**
- **Format**: `<dockerhub-username>/<application-name>:<version-tag>`
- **Examples**:
  - `opiyocrosh/yolo-backend:1.0.0`
  - `opiyocrosh/yolo-client:1.0.0`

### Best Practices Followed

**1. Semantic Versioning:**
- Used `MAJOR.MINOR.PATCH` format (1.0.0)
- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes

**2. Personalization:**
- Used personal Docker Hub username (`opiyocrosh`)
- Named images to reflect application purpose (`yolo-backend`, `yolo-client`)
- Easy identification of image ownership

**3. Immutable Tags:**
- Avoided using `latest` tag in production manifests
- Specified exact version tags (1.0.0) for reproducibility
- Prevents unexpected behavior from image updates

**4. Container Naming:**
- Used descriptive names in manifests
- Kubernetes automatically generates pod names with deployment suffix

**5. Image Documentation:**
- Maintained README with usage instructions
- Documented environment variables and ports
- Included build and run instructions

### Image Repository Links
- Backend: https://hub.docker.com/r/opiyocrosh/yolo-backend
- Frontend: https://hub.docker.com/r/opiyocrosh/yolo-client

### Registry Benefits
- **Public Registry (Docker Hub)**: Easy sharing and pulling
- **No Authentication Required**: Simplifies Kubernetes deployment
- **Version History**: All tagged versions preserved
- **Pull Statistics**: Track image usage

---

## Summary

This Kubernetes implementation demonstrates:
- ✅ Appropriate use of StatefulSets for stateful database workloads
- ✅ Proper service exposure strategy with LoadBalancer for public access
- ✅ Persistent storage implementation using PVCs and volumeClaimTemplates
- ✅ Professional Git workflow with clear commit history
- ✅ Production-ready deployment with debugging and problem-solving
- ✅ Best practices for container image naming and versioning

**Platform:** AWS EKS  
**Live URL:** http://a263a87fb0806478fb57ecdd53f82e49-973885211.us-east-1.elb.amazonaws.com:3000  
**GitHub:** https://github.com/opiyo-cyber/Okoth

---

*End of explanation.md*
