# syntax = docker/dockerfile:1

# Adjust NODE_VERSION as desired
ARG NODE_VERSION=20.7.0
FROM node:${NODE_VERSION}-slim as base

ARG DATABASE_URL

# Next.js/Prisma app lives here
WORKDIR /calcom

# Set production environment
ENV NODE_ENV="production" \
    DATABASE_URL=$DATABASE_URL \
    DATABASE_DIRECT_URL=$DATABASE_URL

# Throw-away build stage to reduce size of final image
FROM base as build

# copy all required files from the monorepo
COPY package.json yarn.lock .yarnrc.yml playwright.config.ts turbo.json git-init.sh git-setup.sh ./
COPY /.yarn ./.yarn
COPY ./apps/api ./apps/api
COPY ./packages ./packages
# TODO: follow up pr to remove dependencies on web
COPY ./apps/web ./apps/web
COPY ./tests ./tests

# Install node modules and dependencies, prune unneeded deps, then build
RUN set -eux; \
    apt-get update -qq && \
    apt-get install -y build-essential openssl pkg-config python-is-python3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives && \
    yarn config set httpTimeout 1200000 && \
    npx turbo prune --scope=@calcom/web --docker && \
    npx turbo prune --scope=@calcom/api --docker && \
    yarn install && \
    yarn turbo run build --filter=@calcom/api


# Final stage
FROM base
WORKDIR /calcom

# Install packages needed for deployment
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y openssl && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built application
COPY --from=build /calcom/package.json ./package.json
COPY --from=build /calcom/node_modules ./node_modules
COPY --from=build /calcom/apps/api/package.json ./apps/api/package.json
COPY --from=build /calcom/apps/api/next-i18next.config.js ./apps/api/next-i18next.config.js
COPY --from=build /calcom/apps/api/next.config.js ./apps/api/next.config.js
COPY --from=build /calcom/apps/api/tsconfig.json ./apps/api/tsconfig.json
COPY --from=build /calcom/apps/api/.next ./apps/api/.next
COPY --from=build /calcom/apps/api/.turbo ./apps/api/.turbo
COPY --from=build /calcom/turbo.json ./turbo.json
COPY --from=build /calcom/yarn.lock ./yarn.lock
COPY --from=build /calcom/packages/config ./packages/config
COPY --from=build /calcom/packages/tsconfig ./packages/tsconfig
COPY --from=build /calcom/packages/types ./packages/types
COPY --from=build /calcom/apps/web/next.config.js ./apps/web/next.config.js
COPY --from=build /calcom/apps/web/next-i18next.config.js ./apps/web/next-i18next.config.js
COPY --from=build /calcom/apps/web/public/static/locales ./apps/web/public/static/locales
COPY --from=build /calcom/apps/web/package.json ./apps/web/package.json
# Expose port 80
EXPOSE 80

# Start cmd, called when docker image is mounted
CMD [ "yarn", "workspace", "@calcom/api", "docker-start-api"]
