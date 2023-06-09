# confluent-platform-gh

# For building the image
docker build -t my-image .

# For running the container
docker run -it my-image:latest

# For SSH into the container
docker exec -it container-id bash

# To check running process
docker ps

# To check images
docker images
