import Hapi from '@hapi/hapi';
import routes from './routes.js';

const init = async () =>
{
  // Membuat instance server Hapi
  const server = Hapi.server(
  {
    port: 3000,
    host: '0.0.0.0',
    routes: { cors: { origin: ['*'] } },
  });

  // Menambahkan route ke server
  server.route(routes);

  await server.start();
  console.log('Server berjalan di %s', server.info.uri);
};

// Handle error jika server gagal berjalan
process.on('unhandledRejection', (err) =>
{
    console.log(err);
    process.exit(1);
});

init();