const axios = require('axios');
const fs = require('fs');
const FormData = require('form-data');

if (process.argv.length !== 4) {
  console.error('Usage: node cli.js [path to bundle] [api key]');
  process.exit(1);
}

const bundlePath = process.argv[2];
const apiKey = process.argv[3];

fs.readFile(bundlePath, (err, data) => {
  if (err) {
    console.error('Error reading bundle file:', err);
    process.exit(1);
  }

  const form = new FormData();
  form.append('bundle', data, {
    filename: bundlePath,
    contentType: 'application/octet-stream',
  });

  axios
    .post('http://0.0.0.0/project/' + apiKey + '/bundle/', form, {
      headers: form.getHeaders(),
    })
    .then((res) => {
      console.log(
        'Successfully uploaded bundle. Server responded with:',
        res.data
      );
    })
    .catch((error) => console.error('Error uploading bundle:', error));
});
