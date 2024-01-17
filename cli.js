const axios = require('axios');
const fs = require('fs');
const FormData = require('form-data');
const archiver = require('archiver');

if (process.argv.length !== 7) {
  console.error(
    'Usage: node cli.js [path to bundle] [path to assets folder] [api key]'
  );
  process.exit(1);
}

const bundlePath = process.argv[2];
const assetsFolderPath = process.argv[3];
const apiKey = process.argv[4];
const branch = process.argv[5];
const version = process.argv[6];

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
        'Successfully uploaded bundle. Server responded with:'
        // res.data
      );
      //remove the assets.zip file
      fs.unlinkSync(zipPath);
    })
    .catch((error) => console.error('Error uploading bundle:', error));
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
