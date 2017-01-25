import { request } from './wrappers';
import { Card, CardAction } from 'trello';


const TRELLO_HOST = 'api.trello.com';


function getId(card: Card|string): string {
    return typeof card === 'string'
        ? card
        : card.id;
}


export default class TrelloClient {
    private key: string;
    private token: string;
    private list: string;


    public constructor({ key, token, list }: { key: string, token: string, list: string }) {
        this.key = key;
        this.token = token;
        this.list = list;
    }


    public async getCards(): Promise<Card[]> {
        return this.get(`lists/${this.list}/cards`);
    }

    public async getCardMoves(card: Card|string): Promise<CardAction[]> {
        return this.get(`cards/${getId(card)}/actions?filter=updateCard:idList`);
    }

    public async archiveCard(card: Card|string): Promise<void> {
        return this.put(`cards/${getId(card)}/closed`, { value: true });
    }

    private async get(path: string): Promise<any> {
        const response = await request({
            host: TRELLO_HOST,
            path: this.formatPath(path),
            method: 'GET'
        });
        return JSON.parse(response);
    }

    private async put(path: string, data: any): Promise<void> {
        await request({
            host: TRELLO_HOST,
            path: this.formatPath(path),
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            }
        }, JSON.stringify(data));
    }

    private formatPath(path: string): string {
        return `/1/${path}${path.indexOf('?') >= 0 ? '&' : '?'}key=${this.key}&token=${this.token}`;
    }
};
