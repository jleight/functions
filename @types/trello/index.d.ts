declare module 'trello' {
    export interface Card {
        id: string;
        name: string;
        closed: boolean;
        dateLastActivity: string;
    }
}
