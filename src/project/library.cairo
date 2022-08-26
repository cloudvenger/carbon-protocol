# SPDX-License-Identifier: MIT
# Carbonable smart contracts written in Cairo v0.1.0 (library.cairo)

%lang starknet

# Starkware dependencies
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.cairo_builtins import HashBuiltin

# Project dependencies
from cairopen.string.ASCII import StringCodec
from openzeppelin.access.ownable import Ownable

namespace CarbonableProject:
    #
    # Constructor
    #

    func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        owner : felt
    ):
        Ownable.initializer(owner)
        return ()
    end

    #
    # Getters
    #

    func image_url{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }() -> (image_url_len : felt, image_url : felt*):
        let (str) = StringCodec.read('image_url')
        return (str.len, str.data)
    end

    func external_url{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }() -> (external_url_len : felt, external_url : felt*):
        let (str) = StringCodec.read('external_url')
        return (str.len, str.data)
    end

    func description{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }() -> (description_len : felt, description : felt*):
        let (str) = StringCodec.read('description')
        return (str.len, str.data)
    end

    func holder{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }() -> (holder_len : felt, holder : felt*):
        let (str) = StringCodec.read('holder')
        return (str.len, str.data)
    end

    func certifier{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }() -> (certifier_len : felt, certifier : felt*):
        let (str) = StringCodec.read('certifier')
        return (str.len, str.data)
    end

    func land{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }() -> (land_len : felt, land : felt*):
        let (str) = StringCodec.read('land')
        return (str.len, str.data)
    end

    func unit_land_surface{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }() -> (unit_land_surface_len : felt, unit_land_surface : felt*):
        let (str) = StringCodec.read('unit_land_surface')
        return (str.len, str.data)
    end

    func country{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }() -> (country_len : felt, country : felt*):
        let (str) = StringCodec.read('country')
        return (str.len, str.data)
    end

    func expiration{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }() -> (expiration_len : felt, expiration : felt*):
        let (str) = StringCodec.read('expiration')
        return (str.len, str.data)
    end

    func total_co2_sequestration{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }() -> (total_co2_sequestration_len : felt, total_co2_sequestration : felt*):
        let (str) = StringCodec.read('total_co2_sequestration')
        return (str.len, str.data)
    end

    func unit_co2_sequestration{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }() -> (unit_co2_sequestration_len : felt, unit_co2_sequestration : felt*):
        let (str) = StringCodec.read('unit_co2_sequestration')
        return (str.len, str.data)
    end

    func sequestration_color{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }() -> (sequestration_color_len : felt, sequestration_color : felt*):
        let (str) = StringCodec.read('sequestration_color')
        return (str.len, str.data)
    end

    func sequestration_type{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }() -> (sequestration_type_len : felt, sequestration_type : felt*):
        let (str) = StringCodec.read('sequestration_type')
        return (str.len, str.data)
    end

    func sequestration_category{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }() -> (sequestration_category_len : felt, sequestration_category : felt*):
        let (str) = StringCodec.read('sequestration_category')
        return (str.len, str.data)
    end

    func background_color{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }() -> (background_color_len : felt, background_color : felt*):
        let (str) = StringCodec.read('background_color')
        return (str.len, str.data)
    end

    func animation_url{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }() -> (animation_url_len : felt, animation_url : felt*):
        let (str) = StringCodec.read('animation_url')
        return (str.len, str.data)
    end

    func youtube_url{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }() -> (youtube_url_len : felt, youtube_url : felt*):
        let (str) = StringCodec.read('youtube_url')
        return (str.len, str.data)
    end

    #
    # Externals
    #

    func set_image_url{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        bitwise_ptr : BitwiseBuiltin*,
        range_check_ptr,
    }(image_url_len : felt, image_url : felt*):
        alloc_locals

        Ownable.assert_only_owner()
        let (str) = StringCodec.ss_arr_to_string(image_url_len, image_url)
        StringCodec.write('image_url', str)
        return ()
    end
end