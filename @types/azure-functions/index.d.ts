interface AzureFunctionContext {
    invocationId: string;
    bindingData: any;
    bindings: any;

    log(text: any): void;
    done(e?: any, o?: { [k: string]: any }): void;
}
