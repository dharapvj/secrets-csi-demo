const express = require('express')
const nunjucks = require('nunjucks')
const winston = require('winston'),
    expressWinston = require('express-winston');
const { readFile } = require('node:fs/promises');
const { resolve } = require('node:path');
const app = express()
// use env PORT
const port = process.env.PORT || 3000;
const data = {
  title: process.env.TITLE_PREFIX || "",
  color: process.env.BGCOLOR || "lemonchiffon", //"YellowGreen",
  message: process.env.MESSAGE || "This is the default messsage"
};

app.use(expressWinston.logger({
  transports: [
    new winston.transports.Console()
  ],
  format: winston.format.combine(
    winston.format.colorize(),
    winston.format.simple()
  ),
  meta: true, // optional: control whether you want to log the meta data about the request (default to true)
  msg: "HTTP {{req.method}} {{req.url}}", // optional: customize the default logging message. E.g. "{{res.statusCode}} {{req.method}} {{res.responseTime}}ms {{req.url}}"
  expressFormat: true, // Use the default Express/morgan request formatting. Enabling this will override any msg if true. Will only output colors with colorize set to true
  colorize: true, // Color the text and status code, using the Express/morgan color palette (text: gray, status: default green, 3XX cyan, 4XX yellow, 5XX red).
  ignoreRoute: function (req, res) { return false; } // optional: allows to skip some log messages based on request and/or response
}))

const logConfiguration = {
  transports: [
      new winston.transports.Console()
  ],
  format: winston.format.combine(
    winston.format.colorize(),
    winston.format.splat(),
    winston.format.simple(),
  ),
};
const logger = winston.createLogger(logConfiguration);

app.use(express.static('public'))

async function logFile() {
  try {
    const filePath = resolve(`${process.env.SECRET_PATH}/${process.env.SECRET_NAME}`);
    const contents = await readFile(filePath, { encoding: 'utf8' });
    return contents;
    //console.log(contents);
  } catch (err) {
    logger.error(err.message);
  }
}


/*app.get('/', (req, res) => {
  res.send('Hello World!')
})
*/
nunjucks.configure('views', {
    autoescape: true,
    express: app,
});
app.get('/', async function(req, res) {
  logger.info('Accessing application!');
  data.content = await logFile();
  res.render('index.html', data);
});

// secrets-csi-demo

app.listen(port, () => {
  logger.info(`Example app listening at http://localhost:${port}`)
})

// var process = require('process')
process.on('SIGINT', () => {
  console.info("Interrupted")
  process.exit(0)
})

