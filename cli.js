const axios = require('axios');
const fs = require('fs');
const FormData = require('form-data');
const archiver = require('archiver');

if (process.argv.length !== 5) {
  console.error('Usage: node cli.js [apiKey] [branch] [version]\n');
  process.exit(1);
}

const bundlePath = './ios/main.jsbundle';
const assetsFolderPath = './ios/assets';
const apiKey = process.argv[2];
const branch = process.argv[3];
const version = process.argv[4];

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
      if (fs.existsSync(zipPath)) fs.unlinkSync(zipPath);
      //remove the assets folder
      if (fs.existsSync(assetsFolderPath))
        fs.rmdirSync(assetsFolderPath, { recursive: true });
      //remove the bundle
      if (fs.existsSync(bundlePath)) fs.unlinkSync(bundlePath);
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
