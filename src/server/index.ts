import express from 'express';
import { redis, createServer, context, getServerPort, reddit } from '@devvit/web/server';

const app = express();

// Middleware for JSON body parsing
app.use(express.json());
// Middleware for URL-encoded body parsing
app.use(express.urlencoded({ extended: true }));
// Middleware for plain text body parsing
app.use(express.text());

const router = express.Router();
router.get('/api/leaderboard', async (_req, res) => {
  res.setHeader("Content-Encoding", "identity")
//   const message = "leaderboard works";
//   res.json({ success: true, message });
  // console.log("leaderboard called")
  // await redis.zAdd(
  //   'leaderboard',
  //   { member: 'louis', score: 37 },
  //   { member: 'fernando', score: 10 },
  //   { member: 'caesar', score: 20 },
  //   { member: 'alexander', score: 25 }
  // );
  console.log("after redis add")
  const out = await redis.zRange('leaderboard', 0, 40, { by: 'score' });
  res.json({output:out})
  
});

router.post('/internal/on-app-install', async (_req, res): Promise<void> => {
  try {
    const post = await reddit.submitCustomPost({
    title: 'krusadia',
    runAs:"APP"
  });;

    res.json({
      status: 'success',
      message: `Post created in subreddit ${context.subredditName} with id ${post.id}`,
    });
  } catch (error) {
    console.error(`Error creating post: ${error}`);
    res.status(400).json({
      status: 'error',
      message: 'Failed to create post',
    });
  }
});

router.post('/api/post-create', async (_req, res) => {
  try {
  const { subredditName } = context;
  const post = await reddit.submitCustomPost({
    runAs: 'USER',
    userGeneratedContent: {
      text: "Hello there! This is a new post from the user's account",
    },
    subredditName,
    title: 'Post Title'
  });
    res.json({
      navigateTo: `https://reddit.com/r/${context.subredditName}/comments/${post.id}`,
    });
  } catch (error) {
    console.error(`Error creating post: ${error}`);
    res.status(400).json({
      status: 'error',
      message: 'Failed to create post',
    });
  }
});

// Use router middleware
app.use(router);

// Get port from environment variable with fallback
const port = getServerPort();

const server = createServer(app);
server.on('error', (err) => console.error(`server error; ${err.stack}`));
server.listen(port);
