// Import from our new component module:
import { AwsS3Website } from "./website";

// Create an instance of our component with the same files as before:
const website = new AwsS3Website("my-website", {
  files: ["index.html"],
});

// And export its autoassigned URL:
export const url = website.url;
