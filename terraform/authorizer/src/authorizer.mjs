export const handler = async (event) => {
  console.log("Authorizer event:", JSON.stringify(event));

  const expectedHeaderName = process.env.CLOUDFRONT_SECRET_HEADER_NAME || "x-cloudfront-secret";
  const expectedHeaderValue = process.env.CLOUDFRONT_SECRET_HEADER_VALUE;

  const headers = event.headers || {};

  const receivedSecret =
    headers[expectedHeaderName] ||
    headers[expectedHeaderName.toLowerCase()] ||
    headers["X-CloudFront-Secret"] ||
    headers["x-cloudfront-secret"];

  const isAuthorized = receivedSecret === expectedHeaderValue;

  return {
    isAuthorized,
    context: {
      source: "cloudfront-secret-authorizer"
    }
  };
};