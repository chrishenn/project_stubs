import * as aws from "@pulumi/aws";
import * as pulumi from "@pulumi/pulumi";

// Arguments for the AWS S3 hosted static website component.
export interface AwsS3WebsiteArgs {
  files: string[]; // a list of files to serve.
}

// A component that encapsulates creating an AWS S3 hosted static website.
export class AwsS3Website extends pulumi.ComponentResource {
  public readonly url: pulumi.Output<string>; // the S3 website url.

  constructor(
    name: string,
    args: AwsS3WebsiteArgs,
    opts?: pulumi.ComponentResourceOptions,
  ) {
    super("quickstart:index:AwsS3Website", name, args, opts);

    // Create an AWS resource (S3 Bucket)
    const bucket = new aws.s3.BucketV2(
      "my-bucket",
      {},
      {
        // Set the parent to the component (step #2) above.
        // Also, do the same for all other resources below.
        parent: this,
      },
    );

    // Turn the bucket into a website:
    const website = new aws.s3.BucketWebsiteConfigurationV2(
      "website",
      {
        bucket: bucket.id,
        indexDocument: {
          suffix: "index.html",
        },
      },
      { parent: this },
    );

    // Permit access control configuration:
    const ownershipControls = new aws.s3.BucketOwnershipControls(
      "ownership-controls",
      {
        bucket: bucket.id,
        rule: {
          objectOwnership: "ObjectWriter",
        },
      },
      { parent: this },
    );

    // Enable public access to the website:
    const publicAccessBlock = new aws.s3.BucketPublicAccessBlock(
      "public-access-block",
      {
        bucket: bucket.id,
        blockPublicAcls: false,
      },
      { parent: this },
    );

    // Create an S3 Bucket object for each file; note the changes to name/source:
    for (const file of args.files) {
      new aws.s3.BucketObject(
        file,
        {
          bucket: bucket.id,
          source: new pulumi.asset.FileAsset(file),
          contentType: "text/html",
          acl: "public-read",
        },
        {
          dependsOn: [ownershipControls, publicAccessBlock],
          parent: this,
        },
      );
    }

    // Capture the URL and make it available as a component property and output:
    this.url = pulumi.interpolate`http://${website.websiteEndpoint}`;
    this.registerOutputs({ url: this.url }); // Signal component completion.
  }
}
