<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Employee Leave Balance</title>
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
</head>
<body>

	<div>
		<jsp:include page="/views/layout/header.jsp"></jsp:include>
		<jsp:include page="/views/layout/menu.jsp"></jsp:include>
	</div>

	<div class="p-6">
		<div class="mb-4 flex items-center justify-between gap-4">
			<input id="searchBox" type="text"
				placeholder="Search by name or code..."
				class="px-4 py-2 border rounded-md w-full max-w-sm" /> <select
				id="sizeSelect" class="ml-4 px-3 py-2 border rounded-md">
				<option value="10">10</option>
				<option value="20">20</option>
				<option value="30">30</option>
				<option value="40">40</option>
				<option value="50">50</option>
			</select>
		</div>

		<div class="overflow-x-auto">
			<div style="max-height: 70vh" class="overflow-y-auto">
				<div class="rounded-md border shadow">
					<table class="min-w-full text-sm text-left">
						<thead class="bg-gray-100 font-semibold">
							<tr>
								<th class="px-4 py-2 cursor-pointer" data-sort="empCode">Employee Code</th>
								<th class="px-4 py-2 cursor-pointer" data-sort="empName">Employee Name</th>
								<th class="px-4 py-2">Hire Date</th>
								<th class="px-4 py-2">Casual Leave</th>
								<th class="px-4 py-2">Earned Leave</th>
								<th class="px-4 py-2">Sick Leave</th>
							</tr>
						</thead>
						<tbody id="leaveTable" class="bg-white divide-y"></tbody>
					</table>
				</div>
			</div>
		</div>

		<div class="mt-4 flex items-center justify-between">
			<button id="prevBtn"
				class="px-4 py-2 bg-blue-500 text-white rounded disabled:opacity-50">Prev</button>
			<span id="pageInfo" class="text-gray-700"></span>
			<button id="nextBtn"
				class="px-4 py-2 bg-blue-500 text-white rounded disabled:opacity-50">Next</button>
		</div>
	</div>

</body>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script>
  // ======================  state  ======================
  let page = 0, size = 10;
  let q = '', sort = 'empName', direction = 'ASC';
  let debounceTimer;

  // ======================  DOM refs  ====================
  const $tbody     = $('#leaveTable');
  const $prevBtn   = $('#prevBtn');
  const $nextBtn   = $('#nextBtn');
  const $pageInfo  = $('#pageInfo');
  const $searchBox = $('#searchBox');

  // ======================  ajax  ========================
  function fetchData () {
    $.ajax({
      url: '<%=request.getContextPath()%>/api/v1/leave/list',
      method: 'GET',
      dataType: 'json',                // <— force JSON
      data: { page, size, q: q.trim(), sort, direction }
    })
    .done(raw => {
      // Fallback if backend sent text/plain
      const data = typeof raw === 'string' ? JSON.parse(raw) : raw;

      // Guard against unexpected payload
      if (!Array.isArray(data.content)) {
        console.warn('API payload missing "content":', data);
        showMessage('Unexpected server response', true);
        return;
      }

      // ---------- table ----------
      $tbody.empty();
      data.content.forEach(row => {
		$tbody.append(
		  '<tr class="hover:bg-gray-50">' +
		    '<td class="px-4 py-2 whitespace-nowrap">' + row.empCode      + '</td>' +
		    '<td class="px-4 py-2">'                + row.empName        + '</td>' +
		    '<td class="px-4 py-2">'                + row.hireDate       + '</td>' +
		    '<td class="px-4 py-2 text-right">'     + row.casualLeave    + '</td>' +
		    '<td class="px-4 py-2 text-right">'     + row.earnedLeave    + '</td>' +
		    '<td class="px-4 py-2 text-right">'     + row.sickLeave      + '</td>' +
		  '</tr>'
		);
      });

      // ---------- pagination ----------
      $pageInfo.text('Page ' + (data.page + 1) + ' / ' + (data.totalPages || 1));
      $prevBtn.prop('disabled', data.first);
      $nextBtn.prop('disabled', data.last);
    })
    .fail(xhr => {
      console.error(xhr);
      const msg = xhr.responseText || 'Server error';
      showMessage(msg, true);
    });
  }

  function showMessage (txt, isErr=false) {
	const $alert = $(
	  '<div class="mt-2 px-4 py-2 rounded text-sm ' +
	    (isErr
	      ? 'bg-red-100 text-red-800'
	      : 'bg-green-100 text-green-800') +
	  '">' + txt + '</div>'
	);
    $pageInfo.after($alert);
    setTimeout(() => $alert.fadeOut(400, () => $alert.remove()), 3500);
  }

  // ======================  events  ======================
  // debounce search
  $searchBox.on('input', function () {
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(() => { q = this.value; page = 0; fetchData(); }, 300);
  });

  $('#sizeSelect').on('change', function () { size = +this.value; page = 0; fetchData(); });

  $prevBtn.on('click', () => { if (page) { page--; fetchData(); }});
  $nextBtn.on('click', () => { page++; fetchData(); });

  // column sort
  $('th[data-sort]').on('click', function () {
    const clicked = $(this).data('sort');
    if (sort === clicked) { direction = direction === 'ASC' ? 'DESC' : 'ASC'; }
    else { sort = clicked; direction = 'ASC'; }
    fetchData();
  });

  $(document).ready(fetchData);
</script>

</html>