FROM node:lts-alpine
# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

RUN npm install --omit=dev
# If you are building your code for production
# RUN npm ci --only=production

# Bundle app source
COPY . .

ENV PORT 3000
#ENV BGCOLOR "LightSalmon"
#ENV MESSAGE "This is default 

EXPOSE $PORT 
CMD [ "node", "index.js" ]
