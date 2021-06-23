import torch

## script to check whether your device is able to use GPU for training

print(torch.cuda.is_available())

id = torch.cuda.current_device() #returns you the ID of your current device
print(torch.cuda.get_device_name(id)) #returns you the name of the device

print(torch.cuda.memory_allocated(id)) #returns you the current GPU memory usage by tensors in bytes for a given device
print(torch.cuda.memory_reserved(id)) #returns you the current GPU memory managed by caching allocator in bytes for a given device, in previous PyTorch versions the command was torch.cuda.memory_cached

torch.cuda.empty_cache()

print(torch.cuda.get_device_properties(id).total_memory)
