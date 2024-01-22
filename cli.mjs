import axios from 'axios';
import fs from 'fs';
import FormData from 'form-data';
import { exec } from 'child_process';
import chalk from 'chalk';
import { program } from 'commander';
import path from 'path';
import { readdir } from 'fs/promises';
import { stat } from 'fs/promises';

// import { fileURLToPath } from 'url';
// import { dirname } from 'path';

// const __dirname = dirname(fileURLToPath(import.meta.url));

program.version('1.0.0');

// program
//   .command('register <username> <password>')
//   .description('Register a new user')
//   .action((username, password) => {
//     axios
//       .post('http://0.0.0.0/user/register', { username, password })
//       .then((res) => {
//         console.log(
//           chalk.green('Successfully registered. User data:'),
//           res.data
//         );
//       })
//       .catch((error) => console.error(chalk.red('Error registering:', error)));
//   });

// program
//   .command('login <username> <password>')
//   .description('Login a user')
//   .action((username, password) => {
//     axios
//       .post('http://0.0.0.0/user/login', { username, password })
//       .then((res) => {
//         console.log(
//           chalk.green('Successfully logged in. User data:'),
//           res.data
//         );
//       })
//       .catch((error) => console.error(chalk.red('Error logging in:', error)));
//   });

program
  .command('uploadbundle <projectPath> <apiKey>')
  .description('Build and upload a bundle')
  .option('-e, --entry <entry>', 'Entry file', 'index.js')
  .option('-m, --minify', 'Minify bundle', false)
  .action(async (projectPath, apiKey, options) => {
    // const absoluteProjectPath = path.resolve(__dirname, projectPath);
    // process.chdir(absoluteProjectPath); // Change the current working directory
    process.chdir(projectPath); // Change the current working directory
    console.log(chalk.green('\n\n Starting uploading bundle and assets  \n\n'));
    exec(
      `npx react-native bundle --entry-file ${options.entry} --platform ios --dev false --bundle-output ios/main.jsbundle --assets-dest ios/assets --minify ${options.minify}`,
      async (err) => {
        if (err) {
          console.error(chalk.red('Error building bundle:', err));
          return;
        }

        fs.readFile(`${projectPath}/ios/main.jsbundle`, async (err, data) => {
          if (err) {
            console.error(chalk.red('Error reading bundle file:', err));
            return;
          }

          const form = new FormData();
          form.append('bundle', data, {
            filename: 'main.jsbundle',
            contentType: 'application/octet-stream',
          });

          console.log(chalk.green('\n\n Bundle added \n\n'));

          // Read the assets directory and append each file to the form
          // const assetsDir = path.join(projectPath, 'ios/assets');
          // const files = await readdir(assetsDir);
          // await Promise.all(
          //   files.map(async (file) => {
          //     const filePath = path.join(assetsDir, file);
          //     const stats = await stat(filePath);
          //     if (stats.isFile()) {
          //       form.append('assets', fs.createReadStream(filePath), file);
          //       console.log(chalk.green(`\n\n Asset added🇮${filePath}  \n\n`));
          //     }
          //   })
          // );

          axios
            .post(`http://127.0.0.1:3003/project/${apiKey}/bundle/`, form, {
              headers: form.getHeaders(),
            })
            .then((res) => {
              // res.data

              console.log(
                chalk.green(
                  '\n\n Successfully uploaded bundle and assets. 🇮🇹  \n\n'
                )
              );
            })
            .catch((error) =>
              console.error(
                chalk.red('Error uploading bundle and assets:', error)
              )
            );
        });
      }
    );
  });

program.parse(process.argv);
