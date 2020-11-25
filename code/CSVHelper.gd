
class_name CSVHelper

var file_: File
var buffer_: PoolStringArray

func _init(full_file_name, mode_flags = File.READ):
	file_ = File.new()
	file_.open(full_file_name, mode_flags)
	print("e: ", file_.get_error(), ", available: ", file_.is_open())

func read_next_byte_from_csv():
	if buffer_.size() == 0 || buffer_.size() == 1:
		buffer_ = file_.get_csv_line()
	var result = buffer_[0] as int
	buffer_.remove(0)
	return result

func store_byte(value):
	file_.store_8(value)

