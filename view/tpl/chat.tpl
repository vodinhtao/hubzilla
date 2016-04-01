<div class="generic-content-wrapper">
	<div class="section-title-wrapper">
		<div class="pull-right">
			<button id="fullscreen-btn" type="button" class="btn btn-default btn-xs" onclick="makeFullScreen(); adjustFullscreenTopBarHeight();"><i class="icon-resize-full"></i></button>
			<button id="inline-btn" type="button" class="btn btn-default btn-xs" onclick="makeFullScreen(false); adjustInlineTopBarHeight();"><i class="icon-resize-small"></i></button>
			{{if $is_owner}}
			<form id="chat-destroy" method="post" action="chat">
				<input type="hidden" name="room_name" value="{{$room_name}}" />
				<input type="hidden" name="action" value="drop" />
				<button class="btn btn-danger btn-xs" type="submit" name="submit" value="{{$drop}}" onclick="return confirmDelete();"><i class="icon-trash"></i>&nbsp;{{$drop}}</button>
			</form>
			{{/if}}
		</div>
		<h2>{{$room_name}}</h2>
		<div class="clear"></div>
	</div>
	<div id="chatContainer" class="section-content-wrapper">
		<div id="chatTopBar">
			<div id="chatLineHolder"></div>
		</div>


		<div class="clear"></div>

		<div id="chatBottomBar" >
			<div class="tip"></div>
			<form id="chat-form" method="post" action="#">
				<input type="hidden" name="room_id" value="{{$room_id}}" />
					<textarea id="chatText" name="chat_text" class="form-control"></textarea>
				<div class="form-group">

				</div>
				<div id="chat-submit-wrapper">
					<div id="chat-submit" class="dropup pull-right">
						<button class="btn btn-default btn-sm dropdown-toggle" type="button" data-toggle="dropdown"><i class="icon-caret-down"></i></button>
						<button class="btn btn-primary btn-sm" type="submit" id="chat-submit" name="submit" value="{{$submit}}">{{$submit}}</button>
						<ul class="dropdown-menu">
							<li class="nav-item"><a class="nav-link" href="{{$baseurl}}/chatsvc?f=&room_id={{$room_id}}&status=online"><i class="icon-circle online"></i>&nbsp;{{$online}}</a></li>
							<li class="nav-item"><a class="nav-link" href="{{$baseurl}}/chatsvc?f=&room_id={{$room_id}}&status=away"><i class="icon-circle away"></i>&nbsp;{{$away}}</a></li>
							<li class="nav-item"><a class="nav-link" href="{{$baseurl}}/chat/{{$nickname}}/{{$room_id}}/leave"><i class="icon-circle leave"></i>&nbsp;{{$leave}}</a></li>
							{{if $bookmark_link}}
							<li class="divider"></li>
							<li class="nav-item"><a class="nav-link" href="{{$bookmark_link}}" target="_blank" ><i class="icon-bookmark"></i>&nbsp;{{$bookmark}}</a></li>
							{{/if}}
						</ul>
					</div>
					<div id="chat-tools" class="btn-toolbar pull-left">
						<div class="btn-group">
							<button id="main-editor-bold" class="btn btn-default btn-sm" title="{{$bold}}" onclick="inserteditortag('b', 'chatText'); return false;">
								<i class="icon-bold jot-icons"></i>
							</button>
							<button id="main-editor-italic" class="btn btn-default btn-sm" title="{{$italic}}" onclick="inserteditortag('i', 'chatText'); return false;">
								<i class="icon-italic jot-icons"></i>
							</button>
							<button id="main-editor-underline" class="btn btn-default btn-sm" title="{{$underline}}" onclick="inserteditortag('u', 'chatText'); return false;">
								<i class="icon-underline jot-icons"></i>
							</button>
							<button id="main-editor-quote" class="btn btn-default btn-sm" title="{{$quote}}" onclick="inserteditortag('quote', 'chatText'); return false;">
								<i class="icon-quote-left jot-icons"></i>
							</button>
							<button id="main-editor-code" class="btn btn-default btn-sm" title="{{$code}}" onclick="inserteditortag('code', 'chatText'); return false;">
								<i class="icon-terminal jot-icons"></i>
							</button>
						</div>
						<div class="btn-group hidden-xs">
							<button id="chat-link-wrapper" class="btn btn-default btn-sm" onclick="chatJotGetLink(); return false;" >
								<i id="chat-link" class="icon-link jot-icons" title="{{$insert}}" ></i>
							</button-->
						</div>
						{{if $feature_encrypt}}
						<div class="btn-group hidden-sm hidden-xs">
							<button id="chat-encrypt-wrapper" class="btn btn-default btn-sm" onclick="red_encrypt('{{$cipher}}', '#chatText', $('#chatText').val()); return false;">
								<i id="chat-encrypt" class="icon-key jot-icons" title="{{$encrypt}}" ></i>
							</button>
						</div>
						{{/if}}
						<div class="btn-group visible-xs visible-sm">
							<button type="button" id="more-tools" class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
								<i id="more-tools-icon" class="icon-caret-down jot-icons"></i>
							</button>
							<ul class="dropdown-menu dropdown-menu-right" role="menu">
								<li class="visible-xs"><a href="#" onclick="chatJotGetLink(); return false;" ><i class="icon-link"></i>&nbsp;{{$insert}}</a></li>
								{{if $feature_encrypt}}
								<li class="divider visible-xs"></li>
								<li class="visible-sm visible-xs"><a href="#" onclick="red_encrypt('{{$cipher}}', '#chatText' ,$('#chatText').val()); return false;"><i class="icon-key"></i>&nbsp;{{$encrypt}}</a></li>
								{{/if}}
							</ul>
						</div>


					</div>
					<div id="chat-rotator-wrapper" class="pull-left">
						<div id="chat-rotator"></div>
					</div>
					<div class="clear"></div>
				</div>
			</form>
		</div>
	</div>
</div>

<script>
var room_id = {{$room_id}};
var last_chat = 0;
var chat_timer = null;

$(document).ready(function() {
	$('#chatTopBar').spin('small');
	chat_timer = setTimeout(load_chats,300);
	$('#chatroom_bookmarks, #vcard').hide();
	$('#chatroom_list, #chatroom_members').show();
	adjustInlineTopBarHeight();
});

$(window).resize(function () {
	if($('.generic-content-wrapper').hasClass('fullscreen')) {
		adjustFullscreenTopBarHeight();
	}
	else {
		adjustInlineTopBarHeight();
	}
	$('#chatTopBar').scrollTop($('#chatTopBar').prop('scrollHeight'));
});

$('#chat-form').submit(function(ev) {
	$('body').css('cursor','wait');
	$.post("chatsvc", $('#chat-form').serialize(),function(data) {
			if(chat_timer) clearTimeout(chat_timer);
			$('#chatText').val('');
			load_chats();
			$('body').css('cursor','auto');
		},'json');
	ev.preventDefault();
});

function load_chats() {
	$.get("chatsvc?f=&room_id=" + room_id + '&last=' + last_chat + ((stopped) ? '&stopped=1' : ''),function(data) {
		if(data.success && (! stopped)) {
			update_inroom(data.inroom);
			update_chats(data.chats);
			$('#chatTopBar').spin(false);
		}
	});
	
	chat_timer = setTimeout(load_chats,10000);

}

function update_inroom(inroom) {
	var html = document.createElement('div');
	var count = inroom.length;
	$.each( inroom, function(index, item) {
		var newNode = document.createElement('div');
		newNode.setAttribute('class', 'member-item');
		$(newNode).html('<img style="height: 32px; width: 32px;" src="' + item.img + '" alt="' + item.name + '" /> ' + '<span class="name">' + item.name + '</span><br /><span class="' + item.status_class + '">' + item.status + '</span>');
		html.appendChild(newNode);
	});
	$('#chatMembers').html(html);
}

function update_chats(chats) {
	var count = chats.length;
	$.each( chats, function(index, item) {
		last_chat = item.id;
		var newNode = document.createElement('div');

		if(item.self) {
			newNode.setAttribute('class', 'chat-item-self clear');
			$(newNode).html('<div class="chat-body-self"><div class="chat-item-title-self"><span class="chat-item-name-self">' + item.name + ' </span><span class="autotime chat-item-time-self" title="' + item.isotime + '">' + item.localtime + '</span></div><div class="chat-item-text-self">' + item.text + '</div></div><img class="chat-item-photo-self" src="' + item.img + '" alt="' + item.name + '" />');
		}
		else {
			newNode.setAttribute('class', 'chat-item clear');
			$(newNode).html('<img class="chat-item-photo" src="' + item.img + '" alt="' + item.name + '" /><div class="chat-body"><div class="chat-item-title"><span class="chat-item-name">' + item.name + ' </span><span class="autotime chat-item-time" title="' + item.isotime + '">' + item.localtime + '</span></div><div class="chat-item-text">' + item.text + '</div></div>');
		}
		$('#chatLineHolder').append(newNode);
		$(".autotime").timeago();

		});
	var elem = document.getElementById('chatTopBar');
	elem.scrollTop = elem.scrollHeight;

}

function chatJotGetLink() {
	reply = prompt("{{$linkurl}}");
	if(reply && reply.length) {
		$('#chat-rotator').spin('tiny');
		$.get('linkinfo?f=&url=' + reply, function(data) {
			addmailtext(data);
			$('#chat-rotator').spin(false);
		});
	}
}

function addmailtext(data) {
	var currentText = $("#chatText").val();
	$("#chatText").val(currentText + data);
}

function adjustFullscreenTopBarHeight() {
	$('#chatTopBar').height($(window).height() - $('#chatBottomBar').outerHeight(true) - $('.section-title-wrapper').outerHeight(true) - 23);
	$('#chatTopBar').scrollTop($('#chatTopBar').prop('scrollHeight'));
}

function adjustInlineTopBarHeight() {
	$('#chatTopBar').height($(window).height() - $('#chatBottomBar').outerHeight(true) - $('.section-title-wrapper').outerHeight(true) - $('nav').outerHeight(true) - 23);
	$('#chatTopBar').scrollTop($('#chatTopBar').prop('scrollHeight'));
}

function isMobile() {
	if( navigator.userAgent.match(/Android/i)
		 || navigator.userAgent.match(/webOS/i)
		 || navigator.userAgent.match(/iPhone/i)
		 || navigator.userAgent.match(/iPad/i)
		 || navigator.userAgent.match(/iPod/i)
		 || navigator.userAgent.match(/BlackBerry/i)
		 || navigator.userAgent.match(/Windows Phone/i)
	 ){
		return true;
	}
	else {
		 return false;
	}
}

$(function(){
	$('#chatText').keypress(function(e){
		if (e.keyCode == 13 && e.shiftKey||isMobile()) {
			//do nothing
		}
		else if (e.keyCode == 13) {
			e.preventDefault();
			$('#chat-form').trigger('submit');
		}
	});
});
</script>
