#include <nanobind/ndarray.h>

#include "example.h"


namespace nb = nanobind;

using myarr = nb::ndarray<int, nb::c_contig, nb::ndim<1>, nb::device::cpu>;
using mytorch = nb::ndarray<nb::pytorch, int, nb::c_contig, nb::ndim<1>, nb::device::cpu>;

namespace pycu_nb {
    mytorch myfn_cpu(const myarr& input)
    {
        size_t n = 1;
        for(size_t i = 0; i < input.ndim(); i++) {
            n *= input.shape(i);
        }

        // Allocate a memory region
        auto data = new int[n];

        // Delete 'data' when the 'owner' capsule expires
        const nb::capsule owner(data, [](void* p) noexcept {
            delete[] static_cast<int*>(p);
        });

        auto output = mytorch(data, {input.shape(0)}, owner);

        const auto inv = input.view();
        const auto outv = output.view();
        for(size_t y = 0; y < inv.shape(0); y++) {
            outv(y) = inv(y) + 1;
        }
        return output;
    }
}
