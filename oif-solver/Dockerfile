FROM node:18-alpine

WORKDIR /app

# Copy package.json and yarn.lock
COPY package.json ./

# Copy the rest of the application
COPY . .

# Install dependencies
RUN yarn install --frozen-lockfile

# Build the application
RUN yarn build

# Command to run the solver
CMD ["yarn", "solver"]
