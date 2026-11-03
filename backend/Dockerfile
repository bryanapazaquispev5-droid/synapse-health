FROM node:22-bookworm-slim
ENV NODE_ENV=production
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev --ignore-scripts
COPY src ./src
ENV PORT=8080
ENV HOST=0.0.0.0
EXPOSE 8080
CMD ["node", "src/aws/local-server.mjs"]
