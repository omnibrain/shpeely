## Shpeely

#### Keep track of your board game scores and compare your performance with other players

This is the complete code of the web site that is currently running at [shpeely.com](https://shpeely.com).

### Installation

Before the installation, make sure you have the following dependencies installed:

 * NodeJS
 * MongoDB
 * Grunt
 * Bower

 1. Clone this repository: ```git clone <this repository> && cd shpeely```
 2. Install the dependencies: ```npm install && bower install```
 3. Compile and run the project: ```grunt serve```
 4. Done! The page should automatically open in your browser.

### Configuration

The following environment variables can be set:



Variable | Value | Default
---------|---------|---------
PROTOCOL | ```https``` or ```http```. If set to https, SSL_CERT and SSL_KEY are required. | http
SSL_KEY | the SSL key file | undefinded
SSL_CERT | the SSL certificate file | undefined
MONGODB_HOST | the mongodb host | localhost:27019
DOMAIN | The domain where the website is hosted | localhost
SESSION_SECRET | The session secret. Set this to a random value | shpeely-secret
RECAPTCHA_SECRET | ReCAPTCHA secret. If not set, there will be no captcha for signing up. | undefined
RECAPTCHA_SITEKEY | ReCAPTCHA site key. If not set, there will be no captcha for signing up. | undefined
FACEBOOK_ID | The Facebook app ID | undefined
FACEBOOK_SECRET | The Facebook app secret | undefined
GOOGLE_ID | The Google app ID | undefined
GOOGLE_SECRET | The Google app secret | undefined
TWITTER_ID | The Twitter app ID | undefined
TWITTER_SECRET | The Twitter app secret | undefined

### Deployment with Docker

Easiest way to deploy Shpeely is by using Docker. A sample docker-compose.yml is provided. When making a new Docker container make sure to build the project first (```grunt build```) before building the Docker image.

