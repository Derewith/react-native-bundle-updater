#!/usr/bin/env node

const { exec } = require('child_process');

if (process.argv.length !== 5) {
  console.error('Usage: node cli.js [apiKey] [branch] [version]\n');
  process.exit(1);
}

const apiKey = process.argv[2];
const branch = process.argv[3];
const version = process.argv[4];

//enter in the node_modules/react-native-bundle-updater folder
process.chdir('node_modules/react-native-bundle-updater');

const scriptName = 'upload:prod ' + apiKey + ' ' + branch + ' ' + version;

// Esegui lo script utilizzando npm run
exec(`npm run ${scriptName}`, (error, stdout, stderr) => {
  if (error) {
    console.error(`Errore durante l'esecuzione dello script: ${stderr}`);
    process.exit(1);
  } else {
    console.log(`Output dello script:\n${stdout}`);
    process.exit(0);
  }
});
