#!/usr/bin/env node

const { exec } = require('child_process');
const yargs = require('yargs');
const {
  REACT_NATIVE_BUNDLE_COMMAND,
  BUNDLE_UPDATER_CLI_COMMAND,
} = require('./constants');

const options = yargs
  .usage('Usage: $0 [options] <apiKey> <branch> <version>')
  .option('m', {
    alias: 'comment',
    describe: 'Add a comment to the bundle',
    type: 'string',
    default: '',
  })
  .demandCommand(3, 'You must provide the apiKey, branch and version')
  .help('h')
  .alias('h', 'help').argv;

const apiKey = options._[0];
const branch = options._[1];
const version = options._[2];
const comment = options.comment;

console.log(`Creating the bundle...`);
exec(REACT_NATIVE_BUNDLE_COMMAND, (error, stdout, stderr) => {
  if (error) {
    console.error(`Error during the first script execution: ${stderr}`);
    process.exit(1);
  } else {
    const cliCommand = `${BUNDLE_UPDATER_CLI_COMMAND} ${apiKey} ${branch} ${version} -m "${comment}"`;
    exec(cliCommand, (_error, _stdout, _stderr) => {
      if (_error) {
        console.error(`Error during the second script execution: ${_stderr}`);
        process.exit(1);
      } else {
        console.log(`${_stdout}`);
        process.exit(0);
      }
    });
  }
});
