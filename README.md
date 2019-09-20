# ruby-dockerfile-example

A simple Ruby application with a Dockerfile to showcase **Dockerfile best practices**.

When passed a URL via the `url` query parameter, the application will parse and return the title of the underlying web page.

## Usage: Standalone

Install dependencies:

```sh
bundle install
```

Run the server:

```sh
bundle exec rackup
```

Place a request:

```sh
curl "http://localhost:3000/?url=google.com"
```

## Usage: Docker

Build the image:

```sh
docker build --build-arg GITHUB_TOKEN=xxx -t my-docker-image:v1 .
```

Run the server inside a container:

```sh
docker run -it --rm -p 3000:3000 my-docker-image:v1
```

Place a request:

```sh
curl "http://localhost:3000/?url=google.com"
```
