pub const List = struct {
    const Self = @This();
    ///This should not be written to by anyone outside.
    capacity: usize,
    data: []i32,

    pub fn create() Self {}
};
