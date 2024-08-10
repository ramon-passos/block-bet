export type Bet = {
    uuid: string;
    value: number;
    description: string;
    result: string;
    owner: object;
    challenger: object;
    status: string;
}
