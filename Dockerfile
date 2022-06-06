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

# Use --from to specify we want to copy something from a previous named stage. 
# /usr/share/nginx/html is an existing directory inside nginx containers where they recommend putting static assets (see https://hub.docker.com/_/nginx)
COPY --from=builder /home/node/app/build /usr/share/nginx/html

# No need to specify a startup command as the nginx image already includes one.

# FROM node:alpine as builder
# WORKDIR /app
# COPY package.json .
# RUN npm install
# COPY . .
# RUN npm run build
 
# FROM nginx
# COPY --from=builder /app/build /usr/share/nginx/html