declare module 'trello' {
    export interface Card {
        id: string;
        name: string;
        closed: boolean;
        dateLastActivity: string;
    }

    export interface CardAction {
        date: string;
        data: CardActionData;
    }

    export interface CardActionData {
        listBefore: ListSummary;
        listAfter: ListSummary;
    }

    export interface ListSummary {
        id: string;
        name: string;
    }
}
