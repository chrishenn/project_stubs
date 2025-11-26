#pragma once

#include <nanobind/ndarray.h>

namespace nb = nanobind;

using myarr = nb::ndarray<int, nb::c_contig, nb::ndim<1>, nb::device::cpu>;
using mytorch = nb::ndarray<nb::pytorch, int, nb::c_contig, nb::ndim<1>, nb::device::cpu>;

using myarr_cu = nb::ndarray<int, nb::c_contig, nb::ndim<1>, nb::device::cuda>;
using mytorch_cu = nb::ndarray<nb::pytorch, int, nb::c_contig, nb::ndim<1>, nb::device::cuda>;

namespace pycu_nb {
    mytorch myfn_cpu(const myarr& input);
    mytorch_cu myfn_gpu(const myarr_cu& input);
}
