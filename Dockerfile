# See explanatory notes of some steps in Dockerfile.dev
FROM node:16-alpine as builder
USER node 

RUN mkdir -p /home/node/app
WORKDIR /home/node/app

COPY --chown=node:node ./package.json ./
RUN npm install

COPY --chown=node:node ./ ./

RUN npm run build

# Another FROM instruction starts a new build stage
FROM nginx

# AWS Beanstalk used to search for an EXPOSE instruction to maps all incoming traffic to its port. In this case we expose port 80 because it is nginx's default port.
# This is no longer needed, as the Linux Platform 2 (the platform in which Beanstalk runs on) requires you to specify this in the compose file.
EXPOSE 80

# Use --from to specify we want to copy something from a previous named stage. 
# /usr/share/nginx/html is an existing directory inside nginx containers where they recommend putting static assets (see https://hub.docker.com/_/nginx)
COPY --from=builder /home/node/app/build /usr/share/nginx/html

# No need to specify a startup command as the nginx image already includes one.

# ! We can also express our file in a simpler way. We don't need the USER intruction and the chown flags, those were 
# ! used in Dockerfile.dev because we needed explicit permissions to access node_modules. 
# FROM node:alpine as builder
# WORKDIR /app
# COPY package.json .
# RUN npm install
# COPY . .
# RUN npm run build
 
# FROM nginx
# EXPOSE 80
# COPY --from=builder /app/build /usr/share/nginx/html