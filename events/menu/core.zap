event LoadStage = {
    from: Client,
    type: Reliable,
    call: ManyAsync,
    data: struct {
        stageId: string,
    },
}