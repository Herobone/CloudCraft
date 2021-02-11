FROM node:10
ENV NODE_ENV=production
ENV VM_NAME=minecraft
ENV DISCORD_TOKEN=invalidtoken
ADD . /env/bot
WORKDIR /env/bot
RUN npm install --only=prod
CMD node src/index.js