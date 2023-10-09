const axios = require('axios');
const fs = require('fs');

if (process.argv.length !== 4) {
  console.error('Usage: node cli.js [path to bundle] [api url]');
  process.exit(1);
}

const bundlePath = process.argv[2];
const apiKey = process.argv[2];

fs.readFile(bundlePath, (err, data) => {
  if (err) {
    console.error('Error reading bundle file:', err);
    process.exit(1);
  }

  axios
    .post('http://0.0.0.0:80/project/' + apiKey + '/bundle/', data, {
      headers: {
        'Content-Type': 'application/octet-stream',
      },
    })
    .then((res) => {
      console.log(
        'Successfully uploaded bundle. Server responded with:',
        res.data
      );
    })
    .catch((err) => console.error('Error uploading bundle:', err));
});
