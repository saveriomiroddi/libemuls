pub trait Logger {
    #[allow(unused_variables)]
    fn log(&mut self, message: String) {}
}
