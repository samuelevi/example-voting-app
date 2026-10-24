FROM node:24.22.1-slim AS base

# add curl for healthcheck, tini for clean signal handling
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl tini && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/app

COPY package*.json ./

RUN npm ci && \
    npm cache clean --force && \
    mv /usr/local/app/node_modules /node_modules

ENV PORT=8080
EXPOSE 8080

# dev: adds nodemon for file watching (used by docker compose locally)
FROM base AS dev
RUN npm install -g nodemon
COPY . .
USER node
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]

# final: the production image, with no npm, corepack or nodemon
FROM base AS final
COPY . .
RUN rm -rf /usr/local/lib/node_modules/npm /usr/local/lib/node_modules/corepack \
    /usr/local/bin/npm /usr/local/bin/npx /usr/local/bin/corepack
USER node
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]