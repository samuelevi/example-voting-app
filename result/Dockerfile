FROM node:24.22.1-slim

# add curl for healthcheck
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl tini && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/app

# have nodemon available for local dev use (file watching)
RUN npm install -g nodemon

COPY package*.json ./

RUN npm ci && \
 npm cache clean --force && \
 mv /usr/local/app/node_modules /node_modules

COPY . .

ENV PORT=8080
EXPOSE 8080

# the official Node image ships with an unprivileged "node" user
USER node

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]
