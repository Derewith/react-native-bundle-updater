#!/usr/bin/env node

const axios = require('axios');
const fs = require('fs');
const FormData = require('form-data');
const archiver = require('archiver');
const yargs = require('yargs');

const options = yargs
  .usage('Usage: node cli.js [options] <apiKey> <branch> <version>')
  .option('m', {
    alias: 'comment',
    describe: 'Add a comment to the bundle (optional)',
    type: 'string',
    default: '',
  })
  .demandCommand(3, 'You must specify apiKey, branch e version')
  .help('h')
  .alias('h', 'help').argv;

const bundlePath = './ios/main.jsbundle';
const assetsFolderPath = './ios/assets';
const apiKey = options._[0];
const branch = options._[1];
const version = options._[2];
const comment = options.comment;

// check if the bundle file and the assets folder exist
if (!fs.existsSync(bundlePath) || !fs.existsSync(assetsFolderPath)) {
  console.error('Errore: La cartella dei bundle o degli assets non esiste.');
  process.exit(1);
}

// remove from the assets folder the node_modules folder if it exists
if (fs.existsSync(assetsFolderPath + '/node_modules'))
  fs.rmdirSync(assetsFolderPath + '/node_modules', { recursive: true });

// Creare un archivio ZIP per la cartella "assets"
const zip = archiver('zip');
const zipPath = 'assets.zip';
const zipStream = fs.createWriteStream(zipPath);
zip.pipe(zipStream);

zip.directory(assetsFolderPath, false);
zip.finalize();

zipStream.on('close', () => {
  const bundleFileName = generateRandomString(12);
  const form = new FormData();
  form.append('bundle', fs.createReadStream(bundlePath), {
    filename: bundleFileName,
    contentType: 'application/octet-stream',
  });
  form.append('assets', fs.createReadStream(zipPath), {
    filename: 'assets.zip',
    contentType: 'application/zip',
  });
  form.append('branch', branch);
  form.append('version', version);
  if (comment && comment !== '') form.append('comment', comment);

  console.log('Uploading bundle...');
  axios
    .post('http://192.168.1.92:3000/project/' + apiKey + '/bundle/', form, {
      headers: {
        'Content-Type': `multipart/form-data;`,
        //also add as data the bundleFileName
        'Content-Disposition': `attachment; filename=${bundleFileName}`,
      },
    })
    .then((res) => {
      console.log(
        'Successfully uploaded bundle.'
        // res.data
      );
      //remove the assets.zip file
      if (fs.existsSync(zipPath)) fs.unlinkSync(zipPath);
      //remove the assets folder
      if (fs.existsSync(assetsFolderPath))
        fs.rmdirSync(assetsFolderPath, { recursive: true });
      //remove the bundle
      if (fs.existsSync(bundlePath)) fs.unlinkSync(bundlePath);
      process.exit(0);
    })
    .catch((error) => {
      console.error('Error uploading bundle:', error);
      process.exit(1);
    });
});

function generateRandomString(length) {
  const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
  let randomString = '';

  for (let i = 0; i < length; i++) {
    const randomIndex = Math.floor(Math.random() * characters.length);
    randomString += characters.charAt(randomIndex);
  }

  return randomString;
}
