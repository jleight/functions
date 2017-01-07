import { request as httpsRequest, RequestOptions } from 'https';

export async function request(options: RequestOptions, data?: string|Buffer) {
    return new Promise<string>((resolve, reject) => {
        const req = httpsRequest(options, response => {
            if (response.statusCode >= 400) {
                reject(new Error(`Request failed, status code: ${response.statusCode}`));
            }

            const body: string[] = [];
            response
                .on('data', chunk => body.push(chunk.toString()))
                .on('end', () => resolve(body.join('')));
        }).on('error', reject);

        if (data) {
            req.write(data);
        }

        req.end();
    });
};
