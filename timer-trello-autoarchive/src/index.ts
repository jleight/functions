import TrelloClient from './utils/TrelloClient';


const KEY_VAR = 'TRELLO_KEY';
const TOKEN_VAR = 'TRELLO_TOKEN';
const LIST_VAR = 'TRELLO_LIST';
const TWO_WEEKS_AGO = new Date().getDate() - 14;


function env(name: string): string {
    const value = process.env[name];
    if (!value) {
        throw new Error(`Environment variable ${name} has not been defined!`);
    }
    return value;
}


async function main(context: AzureFunctionContext): Promise<void> {
    const trello = new TrelloClient({
        key: env(KEY_VAR),
        token: env(TOKEN_VAR),
        list: env(LIST_VAR)
    });

    const cards = (await trello.getCards())
        .filter(card => new Date(card.dateLastActivity).getDate() < TWO_WEEKS_AGO)
        .reverse();

    for (const card of cards) {
        context.log(`card[${card.id}] = "${card.name}"`);
        await trello.archiveCard(card);
    }
}


export function run(context: AzureFunctionContext) {
    main(context)
        .then(() => context.done())
        .catch(e => context.done(e));
};
